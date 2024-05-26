DROP TRIGGER IF EXISTS handle_new_user_trigger ON auth.users CASCADE;

-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION handle_new_user () RETURNS TRIGGER AS $$
BEGIN
    -- 新しいユーザーの user_id を生成
    DECLARE
        new_user_id TEXT := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガーの作成
CREATE
OR REPLACE TRIGGER handle_new_user_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION handle_new_user ();

CREATE
OR REPLACE FUNCTION anonymous_user_update () RETURNS TRIGGER AS $$

BEGIN
    IF NEW.raw_user_meta_data ? 'name' AND NEW.is_anonymous THEN
        NEW.is_anonymous = FALSE; 
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガーの作成
CREATE
OR REPLACE TRIGGER anonymous_user_update_trigger BEFORE
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION anonymous_user_update ();