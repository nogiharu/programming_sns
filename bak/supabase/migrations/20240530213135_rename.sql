-- トリガーを削除
DROP TRIGGER IF EXISTS handle_new_user_trigger ON auth.users CASCADE;

-- 関連する関数を削除
DROP FUNCTION IF EXISTS handle_new_user ();

-- トリガーを削除
DROP TRIGGER IF EXISTS handle_update_user_trigger ON auth.users CASCADE;

-- 関連する関数を削除
DROP FUNCTION IF EXISTS handle_update_user ();

-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION auth.on_insert_user () RETURNS TRIGGER AS $$
    -- 新しいユーザーの user_id を生成
    -- BEFORE INSERTでpublic.usersの挿入が失敗したら、auth.usersへの挿入も失敗させたいが、
    -- auth.usersのidが採番されていないため、AFTER INSERTにしないといけない
    DECLARE
        new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER on_insert_user_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION auth.on_insert_user ();

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
            END;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER on_update_user_trigger BEFORE
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION auth.on_update_user ();

DROP TRIGGER IF EXISTS handle_user_trigger ON public.users CASCADE;

DROP FUNCTION IF EXISTS handle_users ();

------------------------【関数の追加】------------------------
-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION on_user () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- updated_atを自動アップデートを処理する
        NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    ------------------------【INSERTトリガー】------------------------
    -- ELSIF TG_OP = 'INSERT' THEN

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

------------------------【トリガーの追加】------------------------
-- 作成、更新時に`handle_user`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER on_user_trigger BEFORE INSERT
OR
UPDATE ON public.users FOR EACH ROW
EXECUTE FUNCTION on_user ();