#!/usr/bin/env node
const { execFile } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'status.json');
const OPENCLAW = '/Users/kamedanaoki/.npm-global/bin/openclaw';
const OPENGOAT = '/Users/kamedanaoki/.npm-global/bin/opengoat';
const GH = '/opt/homebrew/bin/gh';

function run(cmd, args, timeout = 8000) {
  return new Promise((resolve) => {
    execFile(cmd, args, { timeout, maxBuffer: 1024 * 1024 }, (err, stdout) => {
      if (err) return resolve('');
      resolve(String(stdout || ''));
    });
  });
}

(async () => {
  let telegram = 'unknown';
  let doingTasks = 0;
  let blockedTasks = 0;
  let githubActionsFailed = 0;

  const status = await run(OPENCLAW, ['status']);
  if (/Telegram\s*\|\s*ON\s*\|\s*OK/.test(status)) telegram = 'ok';
  else if (/Telegram\s*\|\s*ON\s*\|/.test(status)) telegram = 'ng';

  const tasksRaw = await run(OPENGOAT, ['task', 'list', '--json']);
  try {
    const parsed = JSON.parse(tasksRaw || '[]');
    const tasks = Array.isArray(parsed) ? parsed : (parsed.tasks || []);
    doingTasks = tasks.filter(t => t.status === 'doing').length;
    blockedTasks = tasks.filter(t => t.status === 'blocked').length;
  } catch {}

  const runsRaw = await run(GH, ['run', 'list', '--repo', 'kameki23/mac-openclaw', '--limit', '20', '--json', 'conclusion']);
  try {
    const runs = JSON.parse(runsRaw || '[]');
    githubActionsFailed = runs.filter(r => r.conclusion === 'failure').length;
  } catch {}

  const out = {
    updatedAt: new Date().toLocaleString('ja-JP', { hour12: false }),
    telegram,
    doingTasks,
    blockedTasks,
    githubActionsFailed,
    dailyCostChecked: false
  };

  fs.writeFileSync(OUT, JSON.stringify(out, null, 2));
  process.stdout.write(`updated: ${OUT}\n`);
})();
