# Core Data Model Definition

## Instructions
When you create the Xcode project with Core Data support, you'll get a `Leevde.xcdatamodeld` file. Open it in Xcode and create the following entities:

## Entity: Language

### Attributes
| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| name | String | No | - | Yes |
| sortOrder | Integer 16 | No | 0 | No |
| createdAt | Date | No | - | No |

### Relationships
| Name | Destination | Type | Delete Rule | Inverse |
|------|-------------|------|-------------|---------|
| vocabularyEntries | VocabularyEntry | To Many | Cascade | language |

### Constraints
- Add a uniqueness constraint on `name` attribute

### Configuration
- Codegen: Class Definition
- Module: Current Product Module

---

## Entity: VocabularyEntry

### Attributes
| Name | Type | Optional | Default | Indexed |
|------|------|----------|---------|---------|
| id | UUID | No | - | Yes |
| word | String | No | - | Yes |
| meaning | String | No | - | No |
| pronunciation | String | No | "" | No |
| note | String | Yes | nil | No |
| audioFileName | String | Yes | nil | No |
| createdAt | Date | No | - | No |
| updatedAt | Date | No | - | No |

### Relationships
| Name | Destination | Type | Delete Rule | Inverse |
|------|-------------|------|-------------|---------|
| language | Language | To One | Nullify | vocabularyEntries |

### Constraints
- Add a compound uniqueness constraint on `word` + `language` relationship

### Configuration
- Codegen: Class Definition
- Module: Current Product Module

---

## Additional Notes

### Fetched Properties
None required.

### Configurations
Use the default configuration.

### After Creating Entities
1. Select the `.xcdatamodeld` file in Xcode
2. Click Editor → Create NSManagedObject Subclass
3. Select both Language and VocabularyEntry entities
4. Click Create
5. This will generate the entity classes automatically

Alternatively, Xcode will auto-generate them when you build the project with "Class Definition" codegen setting.
