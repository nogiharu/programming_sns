SET
    check_function_bodies = OFF;

CREATE
OR REPLACE FUNCTION public.handle_user () RETURNS TRIGGER LANGUAGE plpgsql AS $function$
BEGIN
    
    IF TG_OP = 'UPDATE' THEN
        
        NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    

    END IF;

    RETURN NEW;
END;
$function$;

CREATE
OR REPLACE FUNCTION public.handle_auth_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $function$
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
            new_user_id UUID := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
            BEGIN
                -- 新しいユーザーを public.users テーブルに挿入
                INSERT INTO public.users (id, user_id)
                VALUES (NEW.id, new_user_id);
            END;
    END IF;

    RETURN NEW;
END;
$function$;

CREATE TRIGGER handle_user_trigger BEFORE INSERT
OR
UPDATE ON public.users FOR EACH ROW
EXECUTE FUNCTION handle_user ();