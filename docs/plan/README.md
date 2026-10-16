# Non-AI delivery plan

The user authorized completing all non-AI flows and adding Google/Facebook OAuth.
Implementation and review follow [the delivery contract](../NON_AI_DELIVERY.md).

| Task | Scope | State |
| --- | --- | --- |
| non-ai-baseline | Save recovery copy and return to pushed source without recent AI work | completed |
| non-ai-backend | Persistent, authorized APIs and OAuth | pending audit |
| non-ai-frontend | Connect active user screens to real services/state | pending audit |
| non-ai-review | Independent integration, regression and access-control verification | pending |

OAuth secrets/domain are external inputs requested from the user. Development of the
flow and all independent work continue while those inputs are pending.

