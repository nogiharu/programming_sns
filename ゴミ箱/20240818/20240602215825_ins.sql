CREATE
OR REPLACE FUNCTION insert_auth () RETURNS TRIGGER AS $$
    -- 新しいユーザーの user_id を生成
    -- BEFORE INSERTでpublic.usersの挿入が失敗したら、auth.usersへの挿入も失敗させたいが、
    -- auth.usersのidが採番されていないため、AFTER INSERTにしないといけない
    DECLARE
        new_user_id TEXT := substring(NEW.id, 1, 8);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE
CREATE
OR REPLACE TRIGGER insert_auth_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION insert_auth ();