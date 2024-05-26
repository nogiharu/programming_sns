drop trigger if exists "handle_user_trigger" on "public"."users";

drop function if exists "public"."handle_user"();

drop function if exists "public"."update_updated_at"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_auth_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;


