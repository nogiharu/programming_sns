CREATE
OR REPLACE FUNCTION delete_auth () RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.users
    SET is_deleted = TRUE
    WHERE id = OLD.id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS delete_auth_trigger ON auth.users;

CREATE TRIGGER delete_auth_trigger
AFTER DELETE ON auth.users FOR EACH ROW
EXECUTE FUNCTION delete_auth ();