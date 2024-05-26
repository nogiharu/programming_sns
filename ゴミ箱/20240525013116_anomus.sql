DROP FUNCTION IF EXISTS "public"."handle_new_user" () CASCADE;

SET
    check_function_bodies = OFF;

CREATE
OR REPLACE FUNCTION public.handle_auth_user () RETURNS TRIGGER LANGUAGE plpgsql AS $function$
BEGIN
    
    IF TG_OP = 'UPDATE' THEN
        
        IF NEW.raw_user_meta_data IS NOT NULL AND NEW.is_anonymous THEN
            
            BEGIN
                
                UPDATE auth.users
                SET is_anonymous = FALSE
                WHERE id = NEW.id;

                
                UPDATE public.users
                SET name = NEW.raw_user_meta_data->>'name'
                WHERE id = NEW.id;
            EXCEPTION
                WHEN OTHERS THEN
                    
                    ROLLBACK;
                    RETURN NULL; 
            END;
            
            COMMIT;
        END IF;
    
    ELSIF TG_OP = 'INSERT' THEN
        
        DECLARE
            new_user_id UUID := SUBSTRING(NEW.id::TEXT FROM 1 FOR 8) || (SELECT COUNT(*) FROM auth.users);
            
            BEGIN
                
                INSERT INTO public.users (id, user_id)
                VALUES (NEW.id, new_user_id);
            END;
    END IF;

    RETURN NEW;
END;
$function$;