CREATE TRIGGER delete_auth_trigger AFTER DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION delete_auth();

CREATE TRIGGER insert_auth_trigger AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION insert_auth();

CREATE TRIGGER update_auth_trigger BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION update_auth();


