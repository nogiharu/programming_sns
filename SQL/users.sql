------------------------【テーブルを作成】------------------------
-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS
    public.users (
        -- ユーザーIDを主キーとして設定 (authIDと同じ)
        id UUID NOT NULL PRIMARY KEY,
        -- ユーザーID メンションやログインに使用。変更可
        mention_id TEXT NOT NULL,
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

COMMENT ON COLUMN public.users.mention_id IS 'メンションやログインに使用。変更可';

COMMENT ON COLUMN public.users.name IS '名前';

COMMENT ON COLUMN public.users.profile_photo IS 'プロフィール写真のパスを保存するカラム';

COMMENT ON COLUMN public.users.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.users.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.users.updated_at IS 'レコード更新日時';

------------------------【インデックスの追加】------------------------
CREATE INDEX idx_users_mention_id ON public.users (mention_id);