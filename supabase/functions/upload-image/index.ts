import { PutObjectCommand, S3Client } from 'npm:@aws-sdk/client-s3'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // R2への接続設定
    const s3Client = new S3Client({
      endpoint: Deno.env.get("R2_ENDPOINT") ?? '',
      credentials: {
        accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID") ?? '',
        secretAccessKey: Deno.env.get("R2_SECLET_ACCESS_KEY_ID") ?? '',
      },
      region: "auto",
    });

    // リクエストボディから必要な情報を取得
    const { bucket, key, body } = await req.json();
      
    // S3に画像をアップロード
    const res = await s3Client.send(new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: body,
    }));

    if (res.$metadata.httpStatusCode === 200) {
      // アップロード成功後、パブリックURLを生成
      const url = `https://r2.programming-sns.com/${key}`;
      return new Response(JSON.stringify({ url }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    } else {
      throw new Error("Upload failed");
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500, // Internal Server Error
    });
  }
});
