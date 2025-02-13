-- 【auth.usersのAFTER TRIGGERイベント】
CREATE
OR REPLACE FUNCTION after_auth () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【INSERTトリガー】------------------------
    IF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_mention_id TEXT := NEW.raw_user_meta_data->>'userId';
        BEGIN
            -- 新しいユーザーを public.users テーブルに挿入
            INSERT INTO public.users (id, mention_id)
            VALUES (NEW.id, new_mention_id);
        END;
    ------------------------【UPDATEトリガー】------------------------
    ELSIF TG_OP = 'UPDATE' THEN
        IF (OLD.raw_user_meta_data->>'userId') != (NEW.raw_user_meta_data->>'userId') THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := NEW.raw_user_meta_data->>'userId';
            BEGIN
                -- 新しいユーザーを public.users テーブルに更新
                UPDATE public.users
                SET mention_id = new_user_id
                WHERE id = NEW.id;

                NEW.email = NEW.email_change;
            END;
        END IF;
    ------------------------【DELETEトリガー】------------------------
    ELSIF TG_OP = 'DELETE' THEN
        -- ユーザーを削除としてマーク
        UPDATE public.users
        SET is_deleted = TRUE
        WHERE id = OLD.id;

        RETURN NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- アフタートリガー
CREATE
OR REPLACE TRIGGER after_auth_trigger
AFTER INSERT
OR
UPDATE
OR DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION after_auth ();

-- -- 【auth.usersのBEFORE TRIGGERイベント】
-- CREATE
-- OR REPLACE FUNCTION before_auth () RETURNS TRIGGER AS $$
-- BEGIN
--     ------------------------【UPDATEトリガー】------------------------
--     IF OLD.email_change != NEW.email_change THEN
--         -- 新しいユーザーの user_id を生成
--         DECLARE
--             new_mention_id TEXT := SPLIT_PART(NEW.email_change, '@', 1);
--         BEGIN
--             -- 新しいユーザーを public.users テーブルに更新
--             UPDATE public.users
--             SET mention_id = new_mention_id
--             WHERE id = NEW.id;
--             NEW.email = NEW.email_change;
--         END;
--     END IF;
--     RETURN NEW;
-- END; 
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
-- -- ビフォートリガー
-- CREATE
-- OR REPLACE TRIGGER before_auth_trigger BEFORE
-- UPDATE ON auth.users FOR EACH ROW
-- EXECUTE FUNCTION before_auth ();