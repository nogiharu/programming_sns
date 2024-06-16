drop function if exists "public"."handle_auth_user"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.anonymous_user_update()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    IF NEW.raw_user_meta_data ? 'name' AND NEW.is_anonymous THEN
        NEW.is_anonymous = FALSE; 
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
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


