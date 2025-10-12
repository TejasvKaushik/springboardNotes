import { createClient } from "@supabase/supabase-js";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { topic, noteId } = await req.json();

    // Call OpenAI
    const openaiResponse = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${Deno.env.get("OPENAI_API_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-3.5-turbo",
          messages: [
            {
              role: "user",
              content: `Topic: "${topic}"

Provide a 2-3 sentence summary and 3-4 learning resources.

Respond in JSON:
{
  "summary": "brief explanation",
  "resources": [
    {"title": "Resource name", "url": "https://...", "type": "article"},
    {"title": "Video name", "url": "https://youtube...", "type": "video"}
  ]
}`,
            },
          ],
        }),
      }
    );

    const aiData = await openaiResponse.json();
    const enhancement = JSON.parse(aiData.choices[0].message.content);

    // Update note in database
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    await supabase
      .from("notes")
      .update({
        summary: enhancement.summary,
        resources: enhancement.resources,
        is_processed: true,
      })
      .eq("id", noteId);

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
