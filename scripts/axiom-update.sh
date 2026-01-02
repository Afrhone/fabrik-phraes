#!/usr/bin/env bash
set -euo pipefail

# Generates AXIOM artifacts by invoking a small Node runner

node - <<'NODE'
const fs=require('fs'); const path=require('path');
function readJSON(p, fallback){ try{ return JSON.parse(fs.readFileSync(p,'utf8')); }catch{ return fallback; } }
// Prefer real metrics if provided by the app at axiom/abstract.metrics.json
// Fallback to a tiny demo tree.
const realMetrics = readJSON(path.join(process.cwd(),'axiom','abstract.metrics.json'), null);
const identity={ id:'system', roles:['admin','operator'], tribes:['operators'] };
const ethos={ constraints:[ {id:'safety', weight:.4}, {id:'consent', weight:.4} ], values:{ curiosity:.6, safety:.8 } };
const tree={ root:{ id:'root', feature:'x1', threshold:.5, children:[ { id:'a', feature:'x2', threshold:.2, outcome:.8 }, { id:'b', feature:'x3', threshold:.4, children:[ { id:'c', outcome:.6 } ] } ] } };
// dynamic import TS is not compiled; inline a minimal copy of abstract regression call
function collectPaths(n){ const out=[]; (function dfs(node,depth,feat){ const nf={...feat}; if(node.feature!=null && typeof node.threshold==='number'){ nf[node.feature]=(nf[node.feature]||0)+node.threshold; } if(!node.children||!node.children.length){ out.push({ id:node.id, depth, outcome: node.outcome??.5, features:nf }); return;} for(const c of node.children){ dfs(c,depth+1,nf);} })(n.root,0,{}); return out; }
function coherence(outcomes){ if(!outcomes.length) return 0; const m=outcomes.reduce((a,b)=>a+b,0)/outcomes.length; const v=outcomes.reduce((s,x)=>s+Math.pow(x-m,2),0)/outcomes.length; const harm=1/(1+v*5); return Math.max(0,Math.min(1,harm)); }
function consistency(outcomes){ if(!outcomes.length) return 0; const m=outcomes.reduce((a,b)=>a+b,0)/outcomes.length; const v=outcomes.reduce((s,x)=>s+Math.pow(x-m,2),0)/outcomes.length; return Math.max(0,Math.min(1,1/(1+v*10))); }
function transpose(m){ return m[0].map((_,i)=> m.map(r=> r[i])); }
function matMul(A,B){ return A.map(r=> B[0].map((_,j)=> r.reduce((s,_,k)=> s + r[k]*B[k][j], 0))); }
function vecMul(A,y){ return A.map(r=> r.reduce((s,rij,idx)=> s + rij*y[idx], 0)); }
function dot(a,b){ return a.reduce((s,ai,idx)=> s + ai*(b[idx]||0), 0); }
function solve(A,b){ const n=A.length; const M=A.map(r=> r.slice()); const v=b.slice(); for(let i=0;i<n;i++){ let p=i; for(let r=i+1;r<n;r++){ if(Math.abs(M[r][i])>Math.abs(M[p][i])) p=r; } if(Math.abs(M[p][i])<1e-12) return null; if(p!==i){ [M[i],M[p]]=[M[p],M[i]]; [v[i],v[p]]=[v[p],v[i]]; } const piv=M[i][i]; for(let j=i;j<n;j++) M[i][j]/=piv; v[i]/=piv; for(let r=0;r<n;r++) if(r!==i){ const f=M[r][i]; for(let j=i;j<n;j++) M[r][j]-=f*M[i][j]; v[r]-=f*v[i]; } } return v; }
function regress(paths){ const names=Array.from(new Set(paths.flatMap(p=> Object.keys(p.features)))); const X=paths.map(p=> [1,...names.map(f=> p.features[f]||0)]); const y=paths.map(p=> p.outcome); const XT=transpose(X); const XTX=matMul(XT,X); const XTy=vecMul(XT,y); const b=solve(XTX,XTy)||new Array(X[0].length).fill(0); const intercept=b[0]; const coefs={}; names.forEach((f,i)=> coefs[f]=b[i+1]||0); const yhat=X.map(r=> dot(r,b)); const ym=y.reduce((a,b)=>a+b,0)/y.length; const ssTot=y.reduce((s,yi)=> s+Math.pow(yi-ym,2),0); const ssRes=y.reduce((s,yi,i)=> s+Math.pow(yi-yhat[i],2),0); const r2=ssTot>0? 1-(ssRes/ssTot):1; const eq=`y ~ ${names.map(f=> (coefs[f]||0).toFixed(4)+'*'+f).join(' + ')} + ${intercept.toFixed(4)}`; return { intercept, coefs, r2, equationR:eq } }
let paths;
if(realMetrics && Array.isArray(realMetrics.paths)){
  // Expect paths: [{ features: Record<string,number>, outcome:number }]
  paths = realMetrics.paths.map((p,i)=> ({ id:String(p.id||i), depth: Number(p.depth||0), features: p.features||{}, outcome: Number(p.outcome||0) }));
  console.log('[axiom] using real metrics from axiom/abstract.metrics.json');
} else {
  paths = collectPaths(tree);
}
const outs=paths.map(p=>p.outcome); const report={ paths, indices:{ coherence: coherence(outs), consistency: consistency(outs), effectiveness: 0.5*coherence(outs)+0.5*consistency(outs)}, regression: regress(paths) };
const outDir=path.join(process.cwd(),'axiom','out'); fs.mkdirSync(outDir,{recursive:true}); fs.writeFileSync(path.join(outDir,'analysis.json'), JSON.stringify(report,null,2)); fs.writeFileSync(path.join(outDir,'equation.R.txt'), report.regression.equationR+'\n');
console.log('[axiom] analysis written to axiom/out');
NODE
