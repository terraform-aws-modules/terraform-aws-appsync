// For more examples, refer this doc: https://docs.aws.amazon.com/appsync/latest/devguide/configuring-resolvers-js.html
import { util } from "@aws-appsync/utils";

export function request(ctx) {
  return {};
}

export function response(ctx) {
  return ctx.result.items;
}
