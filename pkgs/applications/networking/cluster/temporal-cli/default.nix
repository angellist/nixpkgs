{ lib, fetchFromGitHub, buildGoModule, installShellFiles, symlinkJoin }:

let
  metaCommon = with lib; {
    description =
      "Command-line interface for running Temporal Server and interacting with Workflows, Activities, Namespaces, and other parts of Temporal";
    homepage = "https://docs.temporal.io/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ aaronjheng ];
  };

  overrideModAttrs = old: {
    # https://gitlab.com/cznic/libc/-/merge_requests/10
    postBuild = ''
      patch -p0 < ${./darwin-sandbox-fix.patch}
    '';
  };

  tctl-next = buildGoModule rec {
    pname = "tctl-next";
    version = "0.10.5";

    src = fetchFromGitHub {
      owner = "temporalio";
      repo = "cli";
      rev = "v${version}";
      hash = "sha256-zHseIXK3REDy6xBGuSV3VoUq/LlktAyTw57GhnuKCIQ";
    };

    vendorHash = "sha256-KeBFf6+G4iu/k9b+UAKzye7WUoE8GH6BCd2DW1OZ/Qo";

    inherit overrideModAttrs;

    nativeBuildInputs = [ installShellFiles ];

    excludedPackages = [ "./cmd/docgen" "./tests" ];

    ldflags =
      [ "-s" "-w" "-X github.com/temporalio/cli/headers.Version=${version}" ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    postInstall = ''
      installShellCompletion --cmd temporal \
        --bash <($out/bin/temporal completion bash) \
        --zsh <($out/bin/temporal completion zsh)
    '';

    __darwinAllowLocalNetworking = true;

    meta = metaCommon // { mainProgram = "temporal"; };
  };

  tctl = buildGoModule rec {
    pname = "tctl";
    version = "1.18.0";

    src = fetchFromGitHub {
      owner = "temporalio";
      repo = "tctl";
      rev = "v${version}";
      hash = "sha256-LcBKkx3mcDOrGT6yJx98CSgxbwskqGPWqOzHWOu6cig=";
    };

    vendorHash = "sha256-5wCIY95mJ6+FCln4yBu+fM4ZcsxBGcXkCvxjGzt0+dM=";

    inherit overrideModAttrs;

    nativeBuildInputs = [ installShellFiles ];

    excludedPackages = [ "./cmd/copyright" ];

    ldflags = [ "-s" "-w" ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    postInstall = ''
      installShellCompletion --cmd tctl \
        --bash <($out/bin/tctl completion bash) \
        --zsh <($out/bin/tctl completion zsh)
    '';

    __darwinAllowLocalNetworking = true;

    meta = metaCommon // { mainProgram = "tctl"; };
  };
in symlinkJoin rec {
  pname = "temporal-cli";
  inherit (tctl) version;
  name = "${pname}-${version}";

  paths = [ tctl-next tctl ];

  passthru = { inherit tctl tctl-next; };

  meta = metaCommon // {
    mainProgram = "temporal";
    platforms = lib.unique (lib.concatMap (drv: drv.meta.platforms) paths);
  };
}
