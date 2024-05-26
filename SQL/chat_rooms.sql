-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.chat_rooms;

-- メッセージテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.chat_rooms (
        -- メッセージIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- ユーザー固有のIDを設定
        owner_user_id UUID NOT NULL,
        -- チャット名
        NAME VARCHAR(2000) NOT NULL,
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.chat_rooms IS 'チャットルーム情報';

-- カラムにコメントを追加
COMMENT ON COLUMN public.chat_rooms.id IS '固有ID';

COMMENT ON COLUMN public.chat_rooms.owner_user_id IS '作成者';

COMMENT ON COLUMN public.chat_rooms.name IS 'チャット名';

COMMENT ON COLUMN public.chat_rooms.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.chat_rooms.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.chat_rooms.updated_at IS 'レコード更新日時';

-- インデックスの追加
CREATE INDEX idx_chat_rooms_owner_user_id ON public.chat_rooms (owner_user_id);

CREATE INDEX idx_chat_rooms_updated_at ON public.chat_rooms (updated_at);

------------------------【トリガーの追加】------------------------
-- 更新時に`update_updated_at`を呼ぶためのトリガーを定義
CREATE
OR REPLACE TRIGGER chat_rooms_updated_at_trigger BEFORE
UPDATE ON public.chat_rooms FOR EACH ROW
EXECUTE FUNCTION update_updated_at ();