// // Follow this setup guide to integrate the Deno language server with your editor:
// // https://deno.land/manual/getting_started/setup_your_environment
// // This enables autocomplete, go to definition, etc.

// // Setup type definitions for built-in Supabase Runtime APIs
// /// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
// import { createClient } from 'npm:@supabase/supabase-js@2'
// import { PutObjectCommand, S3Client, GetObjectCommand } from 'npm:@aws-sdk/client-s3'
// import { getSignedUrl } from 'npm:@aws-sdk/s3-request-presigner'
// import { corsHeaders } from '../_shared/cors.ts'



// Deno.serve(async (req) => {
//   if (req.method === 'OPTIONS') {
//     return new Response('ok', { headers: corsHeaders })
//   }

//   try {

//     const s3Client = new S3Client({
//       endpoint: Deno.env.get("R2_ENDPOINT") ?? '',
//       credentials: {
//         accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID") ?? '',
//         secretAccessKey: Deno.env.get("R2_SECLET_ACCESS_KEY_ID") ?? '',
//       },
//       region: "auto",
//     });
    
        
//     const { bucket,key,body } = await req.json();

//     // オブジェクトをアップロード
//     const uploadResponse = await s3Client.send(new PutObjectCommand({
//       Bucket: bucket,
//       Key: key,
//       Body: body,
//     }));

//     if (uploadResponse.$metadata.httpStatusCode === 200) {
//       // アップロードが成功した場合、Signed URLを生成
//       const getObjectCommand = new GetObjectCommand({
//         Bucket: bucket,
//         Key: key,
//       });

//       const signedUrl = await getSignedUrl(s3Client, getObjectCommand, { expiresIn: 3153600000 }); // 100年有効

//       return new Response(JSON.stringify({ 
//         message: "Upload successful",
//         signedUrl: signedUrl 
//       }), {
//         headers: { ...corsHeaders, 'Content-Type': 'application/json' },
//         status: 200,
//       })
//     } else {
//       throw new Error("Upload failed");
//     }

//   } catch (error) {
//     return new Response(JSON.stringify({ error: error}), {
//       headers: { ...corsHeaders, 'Content-Type': 'application/json' },
//       status: 500,
//     })
//   }
// })

// /* To invoke locally:

//   1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
//   2. Make an HTTP request:

//   curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/delete-user' \
//     --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//     --header 'Content-Type: application/json' \
//     --data '{"name":"Functions"}'

// */
import { createClient } from 'npm:@supabase/supabase-js@2'
import { PutObjectCommand, S3Client } from 'npm:@aws-sdk/client-s3'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const s3Client = new S3Client({
      endpoint: Deno.env.get("R2_ENDPOINT") ?? '',
      credentials: {
        accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID") ?? '',
        secretAccessKey: Deno.env.get("R2_SECLET_ACCESS_KEY_ID") ?? '',
      },
      region: "auto",
    });
    
    const { bucket, key, body } = await req.json();

    // オブジェクトをアップロード（パブリックアクセス可能に設定）
    const res = await s3Client.send(new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: body
    }));

    if (res.$metadata.httpStatusCode === 200) {
      // パブリックURLを生成
      const url = `https://r2.programming-sns.com/${key}`;

      return new Response(JSON.stringify({ url }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    } else {
      throw new Error("Upload failed");
    }

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})