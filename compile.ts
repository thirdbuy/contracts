import path from "path";
import fs from "fs";
//@ts-ignore
import solc from "solc";

const numberOfVersions = 1;

async function compileContracts(names: string[]) {
  const sources: { [key: string]: any } = {};
  for (const name of names) {
    const contractName = `${name}.sol`;
    const contractPath = path.resolve(__dirname, "contracts", contractName);
    const content = fs.readFileSync(contractPath, "utf8");
    sources[contractName] = { content };
  }
  let compileOutput = JSON.parse(
    solc.compile(
      JSON.stringify({
        language: "Solidity",
        sources,
        settings: {
          outputSelection: {
            "*": {
              "*": ["*"],
            },
          },
        },
      }),
      {
        import: (importPath: string) => {
          return {
            contents: fs
              .readFileSync(path.resolve(__dirname, "node_modules", importPath))
              .toString(),
          };
        },
      }
    )
  );
  console.log(names.map((name) => `Compiled ${name}.sol`).join("\n"));
  return compileOutput;
}

async function main() {
  const contractNames: string[] = [];
  for (let i = 1; i <= numberOfVersions; i++) {
    contractNames.push(`StoreV${i}`);
    contractNames.push(`ThirdbuyStoreV${i}`);
  }
  const compiledContracts = await compileContracts(contractNames);
  fs.writeFileSync(
    "./compiled/contracts.json",
    JSON.stringify(compiledContracts)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
