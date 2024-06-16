-- INSERT
CREATE
OR REPLACE FUNCTION insert_auth () RETURNS TRIGGER AS $$
    -- 新しいユーザーの user_id を生成
    -- BEFORE INSERTでpublic.usersの挿入が失敗したら、auth.usersへの挿入も失敗させたいが、
    -- auth.usersのidが採番されていないため、AFTER INSERTにしないといけない
    DECLARE
        new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);

        -- 追加
        NEW.is_anonymous = TRUE; 

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE
CREATE
OR REPLACE TRIGGER insert_auth_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION insert_auth ();

CREATE
OR REPLACE FUNCTION update_auth () RETURNS TRIGGER AS $$
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
                -- 追加
                NEW.is_anonymous = FALSE;
            END;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER update_auth_trigger BEFORE
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION update_auth ();