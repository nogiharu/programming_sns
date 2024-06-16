CREATE
OR REPLACE FUNCTION delete_auth () RETURNS TRIGGER AS $$
    BEGIN
        UPDATE public.users
        SET is_deleted = TRUE
        WHERE id = OLD.id;

        RETURN NULL;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER delete_auth_trigger
AFTER DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION delete_auth ();