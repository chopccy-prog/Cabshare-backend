// routes/inbox.routes.js - FIXED FOR NEW SCHEMA
// Updated to use correct table names after database cleanup
const router = require('express').Router();
const { attachUser, requireAuth } = require('../middleware/auth');
const { supabase } = require('../supabase');

// Apply auth middleware
router.use(attachUser);
router.use(requireAuth);

// GET /inbox - List inbox threads
router.get('/', async (req, res) => {
  try {
    const userId = req.user.id;
    
    console.log('Getting inbox for user:', userId);
    
    // Check if inbox_threads table exists, fallback to manual grouping
    let { data: threads, error } = await supabase
      .from('inbox_threads')
      .select(`
        *,
        rides(id, depart_date, depart_time, routes(origin, destination)),
        rider:rider_id(full_name),
        driver:driver_id(full_name),
        latest_message:inbox_messages(body, created_at)
      `)
      .or(`rider_id.eq.${userId},driver_id.eq.${userId}`)
      .order('updated_at', { ascending: false });

    if (error && error.code === '42P01') {
      // Table doesn't exist, fallback to messages table
      console.log('inbox_threads table not found, using fallback method');
      
      const { data: messages, error: msgError } = await supabase
        .from('messages')
        .select('*')
        .or(`sender_id.eq.${userId},recipient_id.eq.${userId}`)
        .order('created_at', { ascending: false })
        .limit(200);

      if (msgError) {
        console.error('Messages query error:', msgError);
        return res.status(400).json({ error: msgError.message });
      }

      // Group messages by conversation
      const conversationMap = new Map();
      for (const msg of messages || []) {
        const otherId = msg.sender_id === userId ? msg.recipient_id : msg.sender_id;
        const key = `${msg.ride_id || 'general'}:${otherId}`;
        
        if (!conversationMap.has(key)) {
          conversationMap.set(key, {
            ride_id: msg.ride_id,
            other_user_id: otherId,
            last_message: msg.body || msg.text,
            last_message_at: msg.created_at,
            is_driver: msg.sender_id !== userId
          });
        }
      }

      threads = Array.from(conversationMap.values());
    } else if (error) {
      console.error('Inbox threads error:', error);
      return res.status(400).json({ error: error.message });
    }

    console.log('Found threads:', threads?.length || 0);

    // Format response
    const formatted = (threads || []).map(thread => ({
      id: thread.id || `${thread.ride_id}:${thread.other_user_id}`,
      ride_id: thread.ride_id,
      other_user_id: thread.other_user_id || thread.rider_id || thread.driver_id,
      other_user_name: thread.rider?.full_name || thread.driver?.full_name || 'User',
      last_message: thread.last_message || thread.latest_message?.[0]?.body || 'No messages',
      last_message_at: thread.last_message_at || thread.latest_message?.[0]?.created_at || thread.updated_at,
      ride_info: thread.rides ? {
        route: `${thread.rides.routes?.origin || ''} → ${thread.rides.routes?.destination || ''}`,
        date: thread.rides.depart_date,
        time: thread.rides.depart_time
      } : null
    }));

    res.json({ threads: formatted });
  } catch (e) {
    console.error('Inbox error:', e);
    res.status(500).json({ error: e.message });
  }
});

// GET /inbox/:threadId/messages - Get messages for a thread
router.get('/:threadId/messages', async (req, res) => {
  try {
    const userId = req.user.id;
    const threadId = req.params.threadId;
    
    console.log('Getting messages for thread:', threadId);

    let messages = [];
    
    // Try inbox_messages first
    let { data, error } = await supabase
      .from('inbox_messages')
      .select(`
        *,
        sender:sender_id(full_name)
      `)
      .eq('thread_id', threadId)
      .order('created_at', { ascending: true });

    if (error && error.code === '42P01') {
      // Table doesn't exist, try messages table with ride_id filter
      const [rideId, otherId] = threadId.split(':');
      
      const { data: msgData, error: msgError } = await supabase
        .from('messages')
        .select('*')
        .eq('ride_id', rideId)
        .or(`and(sender_id.eq.${userId},recipient_id.eq.${otherId}),and(sender_id.eq.${otherId},recipient_id.eq.${userId})`)
        .order('created_at', { ascending: true });

      if (msgError) {
        console.error('Messages error:', msgError);
        return res.status(400).json({ error: msgError.message });
      }

      messages = msgData || [];
    } else if (error) {
      console.error('Inbox messages error:', error);
      return res.status(400).json({ error: error.message });
    } else {
      messages = data || [];
    }

    console.log('Found messages:', messages.length);

    // Format messages
    const formatted = messages.map(msg => ({
      id: msg.id,
      sender_id: msg.sender_id,
      sender_name: msg.sender?.full_name || 'User',
      body: msg.body || msg.text || msg.message,
      created_at: msg.created_at,
      is_own: msg.sender_id === userId
    }));

    res.json({ messages: formatted });
  } catch (e) {
    console.error('Get messages error:', e);
    res.status(500).json({ error: e.message });
  }
});

// POST /inbox/:threadId/messages - Send a message
router.post('/:threadId/messages', async (req, res) => {
  try {
    const userId = req.user.id;
    const threadId = req.params.threadId;
    const { message, body, text } = req.body;
    
    const messageText = message || body || text;
    if (!messageText) {
      return res.status(400).json({ error: 'Message content is required' });
    }

    console.log('Sending message to thread:', threadId);

    // Try inbox_messages table first
    let { data, error } = await supabase
      .from('inbox_messages')
      .insert({
        thread_id: threadId,
        sender_id: userId,
        body: messageText
      })
      .select()
      .single();

    if (error && error.code === '42P01') {
      // Table doesn't exist, use messages table
      const [rideId, recipientId] = threadId.split(':');
      
      const { data: msgData, error: msgError } = await supabase
        .from('messages')
        .insert({
          ride_id: rideId || null,
          sender_id: userId,
          recipient_id: recipientId,
          text: messageText,
          body: messageText
        })
        .select()
        .single();

      if (msgError) {
        console.error('Send message error:', msgError);
        return res.status(400).json({ error: msgError.message });
      }

      data = msgData;
    } else if (error) {
      console.error('Send inbox message error:', error);
      return res.status(400).json({ error: error.message });
    }

    console.log('Message sent successfully');

    res.json({
      id: data.id,
      sender_id: data.sender_id,
      body: data.body || data.text,
      created_at: data.created_at,
      thread_id: threadId
    });
  } catch (e) {
    console.error('Send message error:', e);
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
