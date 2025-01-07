-- 既存のテーブルを削除
DROP TABLE IF EXISTS public.categories;

-- カテゴリテーブルを作成
CREATE TABLE IF NOT EXISTS
    public.categories (
        -- カテゴリIDを主キーとして設定 (UUIDを自動生成)
        id UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4 (),
        -- カテゴリ名
        NAME VARCHAR(2000) NOT NULL,
        -- 親カテゴリ名
        parent_category VARCHAR(2000),
        -- 消されたか
        is_deleted BOOL DEFAULT FALSE NOT NULL,
        -- レコード作成日時を設定 (UTCタイムゾーンで現在時刻)  
        created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL,
        -- レコード更新日時を設定 (UTCタイムゾーンで現在時刻)  
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE ('utc'::TEXT, NOW()) NOT NULL
    );

-- テーブルのコメントを追加
COMMENT ON TABLE public.categories IS 'カテゴリ情報';

-- カラムにコメントを追加
COMMENT ON COLUMN public.categories.id IS '固有ID';

COMMENT ON COLUMN public.categories.name IS 'カテゴリ名';

COMMENT ON COLUMN public.categories.parent_category IS '親カテゴリ名 (例: 言語別, フレームワーク別)';

COMMENT ON COLUMN public.categories.is_deleted IS '削除フラグ (true: 削除済み, false: 未削除)';

COMMENT ON COLUMN public.categories.created_at IS 'レコード作成日時';

COMMENT ON COLUMN public.categories.updated_at IS 'レコード更新日時';

-- インデックスの追加
CREATE INDEX idx_categories_name ON public.categories (NAME);

CREATE INDEX idx_categories_parent_category ON public.categories (parent_category);

CREATE INDEX idx_categories_updated_at ON public.categories (updated_at);