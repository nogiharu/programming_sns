// deno-lint-ignore-file
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
    // CORSプリフライトリクエストの処理
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // URLパラメータからターゲットURLを取得
        const encodedUrl = new URL(req.url).searchParams.get("url");
        const url = encodedUrl ? decodeURIComponent(encodedUrl) : null;

        if (!url) {
            return new Response("URL parameter is missing or invalid", {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "text/plain" },
            });
        }

        // ターゲットURLにリクエストを送信
        const response = await fetch(url, {
            headers: {
                "User-Agent":
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            },
        });

        // レスポンスのテキストを取得
        const data = await response.text();

        // プロキシされたレスポンスを返す
        return new Response(data, {
            headers: {
                ...corsHeaders,
                "Content-Type": response.headers.get("Content-Type") ||
                    "text/html",
            },
        });
    } catch (error: any) {
        // エラーが発生した場合、エラーメッセージを返す
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 500,
        });
    }
});
