import path from 'path';
import YAML from 'yamljs';

const swaggerDocument = YAML.load(path.join(__dirname, '../docs/swagger.yaml'));

export default swaggerDocument;
