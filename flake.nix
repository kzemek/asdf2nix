{
    outputs = {self}: {
        templates.default = {
            path = ./template;
            description = "A simple flake for installing deps from .tool-versions";
        };
    };
}
