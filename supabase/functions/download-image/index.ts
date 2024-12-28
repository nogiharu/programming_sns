// deno-lint-ignore-file
import { corsHeaders } from '../_shared/cors.ts'
import { decode } from "https://deno.land/std@0.177.0/encoding/base64.ts";

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { url } = await req.json();

    // R2から画像を直接取得
    const imageResponse = await fetch(url);

    if (!imageResponse.ok) {
      throw new Error(`Failed to fetch image: ${imageResponse.statusText}`);
    }

    // 画像データを取得
    const imageArrayBuffer = await imageResponse.arrayBuffer();

    // ArrayBufferをUint8Arrayに変換
    const uint8Array = new Uint8Array(imageArrayBuffer);
    const base64 = Array.from(uint8Array);

    // レスポンスを返す
    return new Response(JSON.stringify({ base64 }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});

function encodeBase64(uint8Array: Uint8Array): string {
  console.log('Encoding Base64...', uint8Array.length);
  
  // Convert the Uint8Array to a regular array of numbers
  const numberArray = Array.from(uint8Array);

  // Use apply with the converted number array
  const binary = String.fromCharCode.apply(null, numberArray);

  return btoa(binary);
}

