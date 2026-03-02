# ai content
CURSOR_RULES_INIT_URL := https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_rules.sh
CURSOR_INIT := scripts/cursor_rules.sh

CURSOR_SKILLS_INIT_URL := https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_skills.sh
CURSOR_SKILLS_INIT := scripts/cursor_skills.sh

CLAUDE_RULES_INIT_URL := https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules.sh
CLAUDE_INIT := scripts/claude_rules.sh

# install cursor init scripts
install-cursor-rule-init:
	@echo "Downloading cursor rules init scripts..."
	@mkdir -p scripts
	@curl -fL $(CURSOR_RULES_INIT_URL) -o $(CURSOR_INIT)
	@chmod +x $(CURSOR_INIT)
	@echo "Done -> $(CURSOR_INIT)"

install-cursor-skill-init:
	@echo "Downloading cursor skills init scripts..."
	@mkdir -p scripts
	@curl -fL $(CURSOR_SKILLS_INIT_URL) -o $(CURSOR_SKILLS_INIT)
	@chmod +x $(CURSOR_SKILLS_INIT)
	@echo "Done -> $(CURSOR_SKILLS_INIT)"

install-claude-rule-init:
	@echo "Downloading claude rules init scripts..."
	@mkdir -p scripts
	@curl -fL $(CLAUDE_RULES_INIT_URL) -o $(CLAUDE_INIT)
	@chmod +x $(CLAUDE_INIT)
	@echo "Done -> $(CLAUDE_INIT)"

# install rules scripts
ai-rules-init: install-cursor-rule-init install-claude-rule-init

# install skills scripts
ai-skills-init: install-cursor-skill-init

cursor-rules:
	@echo "Generating cursor rules..."
	@sh scripts/cursor_rules.sh go

cursor-skills:
	@echo "Generating cursor skills..."
	@sh scripts/cursor_skills.sh go

claude-rules:
	@echo "Generating claude rules..."
	@sh scripts/claude_rules.sh go

# install ai rules
ai-rules-install: ai-rules-init cursor-rules claude-rules

# install ai skills
ai-skills-install: ai-skills-init cursor-skills

# install ai context(contain skill)
ai-context-install: ai-rules-install ai-skills-install
