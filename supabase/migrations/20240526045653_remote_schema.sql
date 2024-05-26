CREATE TRIGGER anonymous_user_update_trigger BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION anonymous_user_update();

CREATE TRIGGER handle_new_user_trigger AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();


