const express=require('express');
const path=require('path');
const app=express();
const PORT=process.env.PORT||3000;
app.use(express.json());
app.use(express.static(path.join(__dirname,'public')));
const products=[
{id:'1',name:'iPhone 14 128GB',price:38999,category:'Mobiles',condition:'Like New',emoji:'📱'},
{id:'2',name:'PlayStation 5 Console',price:44999,category:'Gaming',condition:'Excellent',emoji:'🎮'},
{id:'3',name:'Nike Air Sneakers',price:2999,category:'Fashion',condition:'Like New',emoji:'👟'},
{id:'4',name:'Apple Watch Series',price:18999,category:'Electronics',condition:'Excellent',emoji:'⌚'},
{id:'5',name:'Sony WH-1000XM5',price:22999,category:'Electronics',condition:'Like New',emoji:'🎧'},
{id:'6',name:'MacBook Air M2',price:69999,category:'Laptops',condition:'Excellent',emoji:'💻'}
];
app.get('/api/products',(req,res)=>{const q=(req.query.q||'').toLowerCase();res.json(products.filter(p=>!q||[p.name,p.category,p.condition].join(' ').toLowerCase().includes(q)));});
app.get('*',(req,res)=>res.sendFile(path.join(__dirname,'public','index.html')));
app.listen(PORT,()=>console.log(`RESALE OG running on ${PORT}`));
