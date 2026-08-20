const { createClient } = require('@supabase/supabase-js');
const env = require('./env');

let supabase = null;
let supabaseAdmin = null;

if (env.SUPABASE_URL && env.SUPABASE_ANON_KEY) {
  supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
}

if (env.SUPABASE_URL && env.SUPABASE_SERVICE_ROLE_KEY) {
  supabaseAdmin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
}

module.exports = {
  supabase,
  supabaseAdmin,
};
