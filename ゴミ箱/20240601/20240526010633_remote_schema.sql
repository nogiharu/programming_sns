CREATE TRIGGER handle_auth_user_trigger AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_auth_user();


