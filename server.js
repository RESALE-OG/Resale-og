import express from "express";
import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const app = express();
app.use(express.json({ limit: "2mb" }));
app.use(express.static("public"));

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.warn("Supabase is not connected yet. Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY to .env");
}

const supabase = (supabaseUrl && supabaseKey)
  ? createClient(supabaseUrl, supabaseKey)
  : null;

function requireSupabase(res) {
  if (!supabase) {
    res.status(503).json({ error: "Supabase is not configured. Add values to .env first." });
    return false;
  }
  return true;
}

app.get("/api/products", async (req, res) => {
  if (!requireSupabase(res)) return;
  const q = String(req.query.q || "").trim();

  let query = supabase
    .from("products")
    .select("id,title,description,price,category,condition,image_url,seller_id,created_at")
    .eq("status", "active")
    .order("created_at", { ascending: false });

  if (q) query = query.or(`title.ilike.%${q}%,description.ilike.%${q}%,category.ilike.%${q}%`);

  const { data, error } = await query;
  if (error) return res.status(400).json({ error: error.message });
  res.json(data || []);
});

app.post("/api/products", async (req, res) => {
  if (!requireSupabase(res)) return;
  const { title, description, price, category, condition, image_url, seller_id } = req.body;

  if (!title || !price || !seller_id) {
    return res.status(400).json({ error: "title, price and seller_id are required" });
  }

  const { data, error } = await supabase
    .from("products")
    .insert([{
      title, description: description || "", price: Number(price),
      category: category || "Other", condition: condition || "Used",
      image_url: image_url || "", seller_id, status: "active"
    }])
    .select()
    .single();

  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json(data);
});

app.get("/api/me", async (req, res) => {
  if (!requireSupabase(res)) return;
  const auth = req.headers.authorization;
  if (!auth?.startsWith("Bearer ")) return res.status(401).json({ error: "Missing access token" });

  const token = auth.slice(7);
  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) return res.status(401).json({ error: "Invalid session" });

  res.json({ user });
});

app.listen(process.env.PORT || 3000, () => {
  console.log(`RESALE OG running on http://localhost:${process.env.PORT || 3000}`);
});
