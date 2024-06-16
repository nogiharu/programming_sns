-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION handle_auth_user () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- 匿名ユーザーであり、raw_user_meta_dataがNULLでない場合
        IF NEW.raw_user_meta_data IS NOT NULL AND NEW.is_anonymous THEN
            -- トランザクションを開始
            BEGIN
                -- auth.usersテーブルの更新
                UPDATE auth.users
                SET is_anonymous = FALSE
                WHERE id = NEW.id;

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
        END IF;
    ------------------------【INSERTトリガー】------------------------
    ELSIF TG_OP = 'INSERT' THEN
        -- 新しいユーザーの user_id を生成
        DECLARE
            new_user_id UUID := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
            -- トランザクションを開始
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
OR REPLACE TRIGGER on_auth_user_created BEFORE INSERT
OR
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION handle_auth_user ();