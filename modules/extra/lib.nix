{ lib, rootPath, ... }:
{

  _module.args.dot = {

    # Calculate the subdirectory directory from root the calling module is in
    subDir =
      curPos: # call with __curPos
      let
        modDir = dirOf curPos.file;
      in
      lib.strings.removePrefix (toString rootPath + "/") (toString modDir);

    # Credit to Home Manager
    # https://github.com/nix-community/home-manager/blob/e35c39fca04fee829cecdf839a50eb9b54d8a701/modules/lib/generators.nix
    toHyprconf =
      {
        attrs,
        indentLevel ? 0,
        importantPrefixes ? [ "$" ],
      }:
      let
        inherit (lib)
          all
          concatMapStringsSep
          concatStrings
          concatStringsSep
          filterAttrs
          foldl
          generators
          hasPrefix
          isAttrs
          isList
          mapAttrsToList
          replicate
          attrNames
          ;

        initialIndent = concatStrings (replicate indentLevel "  ");

        toHyprconf' =
          indent: attrs:
          let
            isImportantField =
              n: _: foldl (acc: prev: if hasPrefix prev n then true else acc) false importantPrefixes;
            importantFields = filterAttrs isImportantField attrs;
            withoutImportantFields = fields: removeAttrs fields (attrNames importantFields);

            allSections = filterAttrs (n: v: isAttrs v || isList v) attrs;
            sections = withoutImportantFields allSections;

            mkSection =
              n: attrs:
              if isList attrs then
                let
                  separator = if all isAttrs attrs then "\n" else "";
                in
                (concatMapStringsSep separator (a: mkSection n a) attrs)
              else if isAttrs attrs then
                ''
                  ${indent}${n} {
                  ${toHyprconf' "  ${indent}" attrs}${indent}}
                ''
              else
                toHyprconf' indent { ${n} = attrs; };

            mkFields = generators.toKeyValue {
              listsAsDuplicateKeys = true;
              inherit indent;
            };

            allFields = filterAttrs (n: v: !(isAttrs v || isList v)) attrs;
            fields = withoutImportantFields allFields;
          in
          mkFields importantFields
          + concatStringsSep "\n" (mapAttrsToList mkSection sections)
          + mkFields fields;
      in
      toHyprconf' initialIndent attrs;

  };

}
