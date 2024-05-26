drop function if exists "public"."handle_auth_user"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
  -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT;
            BEGIN
                new_user_id := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
                
                -- 新しいユーザーを public.users テーブルに挿入
                INSERT INTO public.users (id, user_id) VALUES (NEW.id, new_user_id);
                -- トリガーの実行結果として、新しい行を返す
                RETURN NEW;
            END;

$function$
;


