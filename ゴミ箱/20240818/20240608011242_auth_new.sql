-- DELETE existing triggers
DROP TRIGGER IF EXISTS insert_auth_trigger ON auth.users;

DROP TRIGGER IF EXISTS update_auth_trigger ON auth.users;

DROP TRIGGER IF EXISTS delete_auth_trigger ON auth.users;

-- DELETE existing functions
DROP FUNCTION IF EXISTS insert_auth ();

DROP FUNCTION IF EXISTS update_auth ();

DROP FUNCTION IF EXISTS delete_auth ();

-- 【auth.usersのAFTER TRIGGERイベント】
CREATE
OR REPLACE FUNCTION after_auth () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
        BEGIN
            -- 新しいユーザーを public.users テーブルに挿入
            INSERT INTO public.users (id, user_id)
            VALUES (NEW.id, new_user_id);
        END;
    ------------------------【UPDATEトリガー】------------------------
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.email_change IS DISTINCT FROM NEW.email_change THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := SPLIT_PART(NEW.email_change, '@', 1);
            BEGIN
                -- 新しいユーザーを public.users テーブルに更新
                UPDATE public.users
                SET user_id = new_user_id
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

CREATE
OR REPLACE TRIGGER after_auth_trigger
AFTER INSERT
OR
UPDATE
OR DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION after_auth ();