## The “Start the Day”

```
#!/bin/bash
# ~/bin/start-work.sh

echo "Starting your dev environment..."
# Navigate to project
cd ~/projects/my-app || exit
# Pull latest from main
echo "Pulling latest code..."
git checkout main
git pull origin main
# Start Docker containers
echo "Starting Docker..."
docker-compose up -d
# Wait for services to be ready
echo "Waiting for services..."
sleep 10
# Check if services are healthy
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "Backend is healthy"
else
    echo "❌ Backend failed to start"
    exit 1
fi
if curl -f http://localhost:5432 > /dev/null 2>&1; then
    echo "Database is running"
else
    echo "❌ Database failed to start"
    exit 1
fi
# Start frontend dev server in background
echo "Starting frontend..."
cd frontend
npm run dev > /dev/null 2>&1 &
cd ..
# Open VS Code
code .
# Open browser tabs
echo "Opening browser..."
open http://localhost:3000  # Frontend
open http://localhost:3001  # Backend API
open http://localhost:8080  # Database admin
echo "All done."
```

### 2. The “Branch Cleanup”

```
#!/bin/bash
# ~/bin/cleanup-branches.sh

echo "Cleaning up merged branches..."
# Update main branch
git checkout main
git pull origin main
# Delete local branches that have been merged
echo "Local branches to delete:"
git branch --merged main | grep -v "^\*\|main\|master\|develop" | tee /dev/tty | xargs -n 1 git branch -d
# Show branches that still exist remotely but were deleted locally
echo ""
echo "Remote branches (FYI):"
git fetch --prune
git branch -r | grep -v "main\|master\|develop"
echo ""
echo "Cleanup complete!"
```

### 3. The “PR Description Generator” 
script analyzes my commits and generates a template:

```
#!/usr/bin/env python3
# ~/bin/generate-pr-description.py

import subprocess
import sys
def get_commits_since_branch(base_branch="main"):
    result = subprocess.run(
        ["git", "log", f"{base_branch}..HEAD", "--pretty=format:%s"],
        capture_output=True,
        text=True
    )
    return result.stdout.strip().split('\n')
def get_changed_files():
    result = subprocess.run(
        ["git", "diff", "--name-only", "main...HEAD"],
        capture_output=True,
        text=True
    )
    return result.stdout.strip().split('\n')
def generate_description():
    commits = get_commits_since_branch()
    files = get_changed_files()
    
    description = "## What Changed\n\n"
    for commit in commits:
        description += f"- {commit}\n"
    
    description += "\n## Files Modified\n\n"
    for file in files[:10]:  # First 10 files
        description += f"- `{file}`\n"
    
    if len(files) > 10:
        description += f"\n...and {len(files) - 10} more files\n"
    
    description += "\n## Testing\n\n"
    description += "- [ ] Unit tests pass\n"
    description += "- [ ] Integration tests pass\n"
    description += "- [ ] Manually tested locally\n"
    
    description += "\n## Notes for Reviewers\n\n"
    description += "[Add any context reviewers should know]\n"
    
    return description
if __name__ == "__main__":
    print(generate_description())
```

**python ~/bin/generate-pr-description.py | pbcopy**

### 4. The “Environment Sync”
checks what’s missing:

```
#!/bin/bash
# ~/bin/check-env.sh

if [ ! -f .env.example ]; then
    echo "❌ No .env.example found"
    exit 1
fi
if [ ! -f .env ]; then
    echo "❌ No .env found. Creating from example..."
    cp .env.example .env
    echo "Created .env from example. Please fill in values."
    exit 0
fi
echo "Checking for missing environment variables..."
missing=()
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # Extract variable name
    var_name=$(echo "$line" | cut -d= -f1)
    
    # Check if it exists in .env
    if ! grep -q "^$var_name=" .env; then
        missing+=("$var_name")
    fi
done < .env.example
if [ ${#missing[@]} -eq 0 ]; then
    echo "All environment variables are set!"
else
    echo "❌ Missing variables in .env:"
    printf '   - %s\n' "${missing[@]}"
    echo ""
    echo "Add these to your .env file"
fi
```

### 5. The “Test Only What Changed”

```
#!/bin/bash
# ~/bin/test-changed.sh

echo "Testing only changed files..."
# Get list of changed files in git
changed_files=$(git diff --name-only main...HEAD | grep "\.ts$\|\.js$")
if [ -z "$changed_files" ]; then
    echo "No changed files found"
    exit 0
fi
# For each changed file, find and run its test
for file in $changed_files; do
    # Convert src/services/user.ts -> src/services/user.test.ts
    test_file="${file%.*}.test.ts"
    
    if [ -f "$test_file" ]; then
        echo "Running tests for $test_file"
        npm test -- "$test_file"
    else
        echo "⚠️  No test file found for $file"
    fi
done
echo "Done!"
```

### 6. The “Database Reset” 

```
#!/bin/bash
# ~/bin/reset-db.sh

set -e
DB_NAME="myapp_dev"
echo "Dropping database..."
docker-compose exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
echo "Creating database..."
docker-compose exec postgres psql -U postgres -c "CREATE DATABASE $DB_NAME;"
echo "Running migrations..."
npm run migrate
echo "Seeding database..."
npm run seed
echo "Database reset complete!"
```

Add a flag to skip seeding for faster resets:
```
if [[ "$1" != "--no-seed" ]]; then
    echo "🌱 Seeding database..."
    npm run seed
fi
```

### 7. The “Kill Port”
Port 3000 is already in use

```
#!/bin/bash
# ~/bin/kill-port.sh

if [ -z "$1" ]; then
    echo "Usage: kill-port <port_number>"
    exit 1
fi
PORT=$1
echo "Looking for process on port $PORT..."
PID=$(lsof -ti tcp:$PORT)
if [ -z "$PID" ]; then
    echo "No process found on port $PORT"
    exit 0
fi
echo "Killing process $PID on port $PORT..."
kill -9 $PID
echo "Port $PORT is now free"
```

### 8. The “Staging Deploy Check”

```
#!/bin/bash
# ~/bin/deploy-check.sh

echo "Running deploy checks..."
# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "❌ You have uncommitted changes:"
    git status -s
    exit 1
fi
# Check if on main branch
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]]; then
    echo "❌ Not on main branch (currently on $branch)"
    exit 1
fi
# Check if up to date with remote
git fetch origin main
if [[ $(git rev-list HEAD...origin/main --count) != 0 ]]; then
    echo "❌ Local main is not in sync with origin/main"
    exit 1
fi
# Run tests
echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi
# Run linter
echo "🔍 Running linter..."
npm run lint
if [ $? -ne 0 ]; then
    echo "❌ Linting failed"
    exit 1
fi
echo "All checks passed! Safe to deploy."
```

### 9. The “Dependency Update Check” 

```
#!/usr/bin/env python3
# ~/bin/check-safe-updates.py

import json
import subprocess
def get_outdated_packages():
    result = subprocess.run(
        ["npm", "outdated", "--json"],
        capture_output=True,
        text=True
    )
    
    if not result.stdout:
        return {}
    
    return json.loads(result.stdout)
def is_safe_update(current, wanted, latest):
    """Check if update is safe (patch or minor only)"""
    current_parts = current.split('.')
    latest_parts = latest.split('.')
    
    # If major version changed, not safe
    if current_parts[0] != latest_parts[0]:
        return False
    
    return True
def main():
    packages = get_outdated_packages()
    
    if not packages:
        print("All packages are up to date!")
        return
    
    safe_updates = []
    major_updates = []
    
    for name, info in packages.items():
        current = info['current']
        wanted = info['wanted']
        latest = info['latest']
        
        if is_safe_update(current, wanted, latest):
            safe_updates.append((name, current, wanted))
        else:
            major_updates.append((name, current, latest))
    
    if safe_updates:
        print("Safe updates (patch/minor):")
        for name, current, wanted in safe_updates:
            print(f"   {name}: {current} -> {wanted}")
        print("\nRun: npm update")
    
    if major_updates:
        print("\n⚠️  Major updates (review carefully):")
        for name, current, latest in major_updates:
            print(f"   {name}: {current} -> {latest}")
        print("\nUpdate manually after reviewing changelogs")
if __name__ == "__main__":
    main()
```

### 10. The “Log Search”

```
#!/bin/bash
# ~/bin/search-logs.sh

SERVICE=${1:-backend}  # Default to backend service
SEARCH_TERM=${2:-error}  # Default to searching for "error"
LINES=${3:-50}  # Default to showing 50 lines
echo "Searching last $LINES lines of $SERVICE logs for '$SEARCH_TERM'..."
docker-compose logs --tail=$LINES $SERVICE | grep -i "$SEARCH_TERM" --color=always
# Show count
count=$(docker-compose logs --tail=$LINES $SERVICE | grep -i "$SEARCH_TERM" | wc -l)
echo ""
echo "Found $count matches"
```

Usage examples:
```
search-logs backend "user not found"
search-logs postgres "connection"
search-logs frontend "404" 100
```

### 11. The “Create Component” 

```
#!/bin/bash
# ~/bin/create-component.sh

if [ -z "$1" ]; then
    echo "Usage: create-component ComponentName"
    exit 1
fi
COMPONENT=$1
DIR="src/components/$COMPONENT"
mkdir -p $DIR
# Create component file
cat > "$DIR/$COMPONENT.tsx" << EOF
import React from 'react';
import './$COMPONENT.css';
interface ${COMPONENT}Props {
  // Add props here
}
export const $COMPONENT: React.FC<${COMPONENT}Props> = (props) => {
  return (
    <div className="${COMPONENT}">
      <h2>$COMPONENT Component</h2>
    </div>
  );
};
EOF
# Create CSS file
cat > "$DIR/$COMPONENT.css" << EOF
.$COMPONENT {
  /* Add styles here */
}
EOF
# Create test file
cat > "$DIR/$COMPONENT.test.tsx" << EOF
import { render, screen } from '@testing-library/react';
import { $COMPONENT } from './$COMPONENT';
describe('$COMPONENT', () => {
  it('renders without crashing', () => {
    render(<$COMPONENT />);
    expect(screen.getByText('$COMPONENT Component')).toBeInTheDocument();
  });
});
EOF
# Create index file for easy importing
cat > "$DIR/index.ts" << EOF
export { $COMPONENT } from './$COMPONENT';
EOF
echo "Component $COMPONENT created at $DIR"
```

Usage: create-component UserProfile


### 12. The “Backup"
creates a temporary backup:

```
#!/bin/bash
# ~/bin/backup-work.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/work-backups
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")
mkdir -p $BACKUP_DIR
# Create backup filename
BACKUP_FILE="$BACKUP_DIR/${PROJECT_NAME}_${TIMESTAMP}.tar.gz"
echo "Creating backup..."
# Exclude node_modules and other large directories
tar -czf "$BACKUP_FILE" \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='.next' \
    .
echo "Backup created: $BACKUP_FILE"
# Keep only last 10 backups
cd $BACKUP_DIR
ls -t ${PROJECT_NAME}_*.tar.gz | tail -n +11 | xargs -r rm
echo "Cleaned up old backups (keeping last 10)"
```

## Usage
Set PATH:
```
# In ~/.zshrc or ~/.bashrc
export PATH="$HOME/bin:$PATH"
```

**set aliases**
```
alias work='start-work.sh'
alias clean='cleanup-branches.sh'
alias testc='test-changed.sh'
alias resetdb='reset-db.sh'
alias kp='kill-port.sh'
```

**workflow**
```
work          # Start work
    ... code  ...
testc         # Run tests for what changed
  ... more coding ...
resetdb       # Reset database as needed
kp 3000       # Kill port as needed
clean         # Clean up branches
```

**Automate the tiny things that break your flow**

## Tracking

1. Write a record of your day actions
2. Write in how you spend that time.
3. Write the names of the people you meet.
4. Write a gratitude note
5. Write down what almost pulled you away from what you want to focus on
6. Capture your doodling ideas
7. It’s an investment in yourself



