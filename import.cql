LOAD CSV WITH HEADERS FROM "file:///fewshot.csv" AS row
CREATE (:Question {question: row.Question, cypher: row.Cypher})

MATCH (f:Fewshot)
WITH f.Question AS question, f
CALL dbms.functions.execute("https://api.openai.com/v1/engines/davinci-codex/completions", { 
  headers: apoc.map.merge([
    {Authorization: "Bearer " + $openai_api_key},
    {Content-Type: "application/json"}
  ]),
  payload: apoc.convert.toJson({
    prompt: question,
    max_tokens: 50, // Adjust as needed
    model: "davinci-codex"
  }),
  method: "POST"
}) YIELD value
SET f.embedding = value.choices[0].embedding;


CALL db.index.fulltext.createNodeIndex('student_names_index', ['Student'], ['name']);
CALL db.index.fulltext.createNodeIndex('subject_names_index', ['Subject'], ['name']);


CALL db.index.fulltext.createNodeIndex('student_fulltext_index', ['Student'], ['name']);
CALL db.index.fulltext.createNodeIndex('subject_fulltext_index', ['Subject'], ['name']);