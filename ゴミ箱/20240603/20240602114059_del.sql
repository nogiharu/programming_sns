CREATE
OR REPLACE FUNCTION delete_auth () RETURNS TRIGGER AS $$
    BEGIN
        UPDATE public.users
        SET is_deleted = TRUE
        WHERE id = NEW.id;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER delete_auth_trigger BEFORE DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION delete_auth ();