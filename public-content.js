import {SUPABASE_URL,SUPABASE_ANON_KEY,CONFIGURED} from './supabase-config.js';
if(CONFIGURED){
 try{
  const response=await fetch(`${SUPABASE_URL}/rest/v1/site_content?select=key,value`,{headers:{apikey:SUPABASE_ANON_KEY,Authorization:`Bearer ${SUPABASE_ANON_KEY}`}});
  if(!response.ok)throw new Error(`Content request failed (${response.status})`);
  const rows=await response.json();const values=Object.fromEntries(rows.map(r=>[r.key,r.value]));
  const setBackground=(nodes,images)=>{if(!Array.isArray(images))return;nodes.forEach((node,i)=>{if(images[i]&&/^https:\/\//.test(images[i]))node.style.backgroundImage=`url(${JSON.stringify(images[i])})`})};
  setBackground(document.querySelectorAll('.hero-slide'),values.homePhotos);
  const page=document.body.dataset.page;
  setBackground(document.querySelectorAll('.page-slide'),values.pagePhotos?.[page]);
  document.querySelectorAll('[data-edit-price]').forEach(el=>{const value=values.prices?.[el.dataset.editPrice];if(typeof value==='string'&&value.trim())el.textContent=value});
  if(typeof values.quote==='string'&&values.quote.trim())document.querySelectorAll('[data-testimonial]').forEach(el=>el.textContent=values.quote);
 }catch(err){console.warn('IMBA CMS unavailable; using built-in site content.',err)}
}
