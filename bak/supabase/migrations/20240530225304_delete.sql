-- DELETE
CREATE
OR REPLACE FUNCTION auth.on_delete_user () RETURNS TRIGGER AS $$
    BEGIN
        UPDATE public.users
        SET is_deleted = TRUE
        WHERE id = NEW.id;
        
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER on_delete_user_trigger BEFORE DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION auth.on_delete_user ();

CREATE
OR REPLACE FUNCTION auth.on_update_user () RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.email_change != NEW.email_change THEN
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

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;