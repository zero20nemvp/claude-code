**Note:** This plugin requires `lock.yml` to be present in context to function.

# ILX Pipeline Test Cases

Validation test cases for Claude→ILX→Local LLM→Code pipeline.

## Test Cases

### 1. Simple Entity (bidding.ilx)
- Single entity with basic constraints
- Triggers and edge cases
- Result: ✓ Pass

### 2. Complex Entity (complex_bidding.ilx)
- Multiple constraints including creditScore
- Optional proxy_max field
- Multiple edge cases with triggers
- Result: ✓ Pass (with escalation for some constraints)

### 3. Multi-Entity (from ILX SKILL.md)
```
::ecommerce
  User{email!,name!,Cart⊃cart}
  Cart{total∈ℝ⁺,items∈[Item]}
  Item{sku!,qty∈ℤ⁺,price∈ℝ⁺}
  #checkout:@user→Order|cart.total>0∧items.all(in_stock)⟹λsend_confirmation
```
- Multiple related entities
- Array relationships
- Complex constraint with all() quantifier

### 4. View Component (from ILX SKILL.md)
```
::dashboard/stats_card.html.erb
  article.card.bg-white.rounded-lg.shadow
    h3.text-lg.font-semibold{=@title}
    p.text-3xl.font-bold{=@value}
    span.text-sm.text-gray-500{=@trend}
  @click:card→toggle_details
```
- View template with Tailwind classes
- Data bindings
- Action handlers

### 5. Controller Feature (from ILX SKILL.md)
```
::posts#create:@author→Post
  |!banned∧title.length>5
  edge:spam_detected→reject:spam
  edge:duplicate_title→confirm:overwrite
  ⟹λindex_search
  ⟹λnotify_followers
```
- Controller action semantics
- Multiple triggers
- Edge case handling

## Validation Commands

```bash
# Test simple bidding
ruby ilx_pipeline.rb test_ilx/bidding.ilx

# Test complex bidding (should trigger feedback loop)
ruby ilx_pipeline.rb -v test_ilx/complex_bidding.ilx

# Generate code only (skip review)
ruby ilx_to_code.rb test_ilx/bidding.ilx

# Extract requirements from ILX
ruby ilx_review.rb -e test_ilx/bidding.ilx
```

## Results

All test cases validate that:
1. Local LLM (qwen2.5-coder:14b) generates valid Ruby from ILX
2. Generated code passes `ruby -c` syntax check
3. Constraints become Rails validations
4. Edge cases become guard clauses
5. Triggers become callbacks
