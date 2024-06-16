CREATE VIEW
    public.messages_view AS
SELECT
    m.id AS message_id,
    m.send_by_user_id,
    m.chat_room_id,
    m.message,
    m.message_type,
    m.reactions,
    m.reacted_user_ids,
    m.is_deleted,
    m.created_at AS message_created_at,
    m.updated_at AS message_updated_at,
    r.id AS reply_id,
    r.reply_by_user_id,
    r.reply_message,
    r.reply_message_type,
    r.created_at AS reply_created_at,
    r.updated_at AS reply_updated_at
FROM
    public.messages m
    LEFT JOIN public.replies r ON m.id = r.message_id;