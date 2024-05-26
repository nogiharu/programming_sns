-- -- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION handle_auth_user () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- 匿名ユーザーであり、raw_user_meta_dataがNULLでない場合
        IF NEW.raw_user_meta_data IS NOT NULL AND NEW.is_anonymous THEN
            -- auth.usersテーブルの行型変数
            DECLARE
                updated_auth_user auth.users%ROWTYPE;
            -- トランザクションを開始
            BEGIN
                -- auth.usersテーブルの更新
                UPDATE auth.users
                SET is_anonymous = FALSE
                WHERE id = NEW.id
                RETURNING * INTO updated_auth_user;
                -- public.usersテーブルの更新
                UPDATE public.users
                SET name = NEW.raw_user_meta_data->>'name'
                WHERE id = NEW.id;
            EXCEPTION
                WHEN OTHERS THEN
                    -- ロールバック
                    ROLLBACK;
                    RETURN NULL; -- トリガーを終了し、変更をロールバック
            END;
            -- トランザクションをコミット
            COMMIT;
            -- 更新後の auth.users レコードを返す
            RETURN updated_auth_user;
        END IF;
    ------------------------【INSERTトリガー】------------------------
    ELSIF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_user_id TEXT := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
            BEGIN
                -- 新しいユーザーを public.users テーブルに挿入
                INSERT INTO public.users (id, user_id)
                VALUES (NEW.id, new_user_id);
            END;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガーの作成
CREATE
OR REPLACE TRIGGER handle_auth_user_trigger BEFORE INSERT
OR
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION handle_auth_user ();

-- 操作を処理するトリガー関数
-- DROP TRIGGER IF EXISTS handle_auth_user_trigger ON auth.users CASCADE;
-- CREATE
-- OR REPLACE FUNCTION handle_auth_user () RETURNS TRIGGER AS $$
-- BEGIN
--     -- 新しいユーザーの user_id を生成
--     DECLARE
--         new_user_id TEXT := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
--     BEGIN
--         -- 新しいユーザーを public.users テーブルに挿入
--         INSERT INTO public.users (id, user_id)
--         VALUES (NEW.id, new_user_id);
--     END;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
-- -- トリガーの作成
-- CREATE
-- OR REPLACE TRIGGER handle_auth_user_trigger
-- AFTER INSERT ON auth.users FOR EACH ROW
-- EXECUTE FUNCTION handle_auth_user ();