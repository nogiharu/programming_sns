------------------------【テーブルを作成】------------------------
-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS
    public.users (
        -- ユーザーIDを主キーとして設定 (authIDと同じ)
        id UUID NOT NULL PRIMARY KEY,
        -- ユーザーID メンションやログインに使用。変更可
        user_id TEXT NOT NULL,
        -- ユーザー名
        NAME VARCHAR NOT NULL DEFAULT '名前はまだない',
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT TIMEZONE ('utc'::TEXT, NOW()),
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT TIMEZONE ('utc'::TEXT, NOW()),
        -- プロフィール写真のパスを保存するカラム
        profile_photo VARCHAR,
        -- 消されたか
        is_deleted BOOL NOT NULL DEFAULT FALSE
    );

------------------------【テーブルのコメントを追加】------------------------
COMMENT ON TABLE public.users IS 'ユーザー名などのユーザー情報を保持する';

------------------------【カラムにコメントを追加】------------------------
COMMENT ON COLUMN public.users.id IS '固有ID';

COMMENT ON COLUMN public.users.user_id IS 'メンションやログインに使用。変更可';

COMMENT ON COLUMN public.users.name IS '名前';

COMMENT ON COLUMN public.users.profile_photo IS 'プロフィール写真のパスを保存するカラム';

COMMENT ON COLUMN public.users.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.users.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.users.updated_at IS 'レコード更新日時';

------------------------【インデックスの追加】------------------------
CREATE INDEX idx_users_user_id ON public.users (user_id);

------------------------【関数の追加】------------------------
-- 操作を処理するトリガー関数
CREATE
OR REPLACE FUNCTION on_user () RETURNS TRIGGER AS $$
BEGIN
    ------------------------【UPDATEトリガー】------------------------
    IF TG_OP = 'UPDATE' THEN
        -- updated_atを自動アップデートを処理する
        NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    ------------------------【INSERTトリガー】------------------------
    -- ELSIF TG_OP = 'INSERT' THEN

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

------------------------【トリガーの追加】------------------------
-- 作成、更新時に`handle_user`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER on_user_trigger BEFORE INSERT
OR
UPDATE ON public.users FOR EACH ROW
EXECUTE FUNCTION on_user ();

-- INSERT
CREATE
OR REPLACE FUNCTION insert_auth () RETURNS TRIGGER AS $$
    -- 新しいユーザーの user_id を生成
    -- BEFORE INSERTでpublic.usersの挿入が失敗したら、auth.usersへの挿入も失敗させたいが、
    -- auth.usersのidが採番されていないため、AFTER INSERTにしないといけない
    DECLARE
        new_user_id TEXT := SPLIT_PART(NEW.email, '@', 1);
    BEGIN
        -- 新しいユーザーを public.users テーブルに挿入
        INSERT INTO public.users (id, user_id)
        VALUES (NEW.id, new_user_id);

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE
CREATE
OR REPLACE TRIGGER insert_auth_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION insert_auth ();

CREATE
OR REPLACE FUNCTION update_auth () RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.email_change != NEW.email_change THEN
            -- 新しいユーザーの user_id を生成
            DECLARE
                new_user_id TEXT := SPLIT_PART(NEW.email_change, '@', 1);
            BEGIN
                -- 新しいユーザーを public.users テーブルに更新
                UPDATE public.users
                SET user_id = new_user_id
                WHERE id = NEW.id;

                NEW.email = NEW.email_change;
            END;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR REPLACE TRIGGER update_auth_trigger BEFORE
UPDATE ON auth.users FOR EACH ROW
EXECUTE FUNCTION update_auth ();

DROP FUNCTION on_insert_auth ();

DROP FUNCTION on_update_auth ();