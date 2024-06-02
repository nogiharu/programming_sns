drop function if exists "public"."anonymous_user_update"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- 新しいユーザーの user_id を生成
    DECLARE
        new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);
    END;
    RETURN NEW;
END;
$function$
;


