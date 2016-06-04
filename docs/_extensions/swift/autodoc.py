import re
import fnmatch
import os

from sphinx.ext.autodoc import Documenter, bool_option

class SwiftClassAutoDocumenter(Documenter):
    objtype = 'swiftclass'

    # TODO: vlass ivars

    def __init__(self, *args, **kwargs):
        super(SwiftClassAutoDocumenter, self).__init__(*args, **kwargs)
        self.func_pattern = re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<static>class\s+)?func\s+(?P<name>[a-zA-Z_][a-zA-Z0-9_]*\b)(?P<rest>[^{]*)')
        self.init_pattern = re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<static>class\s+)?init\s*(?P<rest>[^{]*)')
        self.param_pattern = re.compile(r'^\s*- [pP]arameter\s*(?P<param>[^:]*):\s*(?P<desc>.*)')
        self.return_pattern = re.compile(r'^\s*- [rR]eturn[s]?\s*:\s*(?P<desc>.*)')
        self.throws_pattern = re.compile(r'^\s*- [tT]hrow[s]?\s*:\s*(?P<desc>.*)')

        self.files = []
        for path in self.env.config.swift_search_path:
            for root, dirnames, filenames in os.walk(path):
                for filename in fnmatch.filter(filenames, '*.swift'):
                    self.files.append(os.path.join(root, filename))

    @classmethod
    def can_document_member(cls, member, membername, isattr, parent):
        print("can document?", member, membername, isattr, parent)
        return True

    def generate(self, more_content = None, real_modname = None, check_module = False, all_members = False):
        # find class in swift files
        swift_class_sig = re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?class\s+(?P<name>' + self.name + r'\b)(\s*:\s*(?P<type>[^{]*))*')

        for file in self.files:
            with open(file, "r") as fp:
                content = fp.readlines()
                for (index, line) in enumerate(content):
                    match = swift_class_sig.match(line)
                    if match:
                        match = match.groupdict()
                        if match['scope'].strip() == 'public' or all_members:
                            self.document_class(file, content, index, match, all_members=all_members)
                            return

    def get_doc_block(self, content, line):
        # search upwards for documentation lines
        doc_block = []
        for i in range(line, 0, -1):
            l = content[i].strip()
            if l.startswith('///'):
                doc_block.append(l[4:].strip())
                continue
            break
        return doc_block

    def document_class(self, file, content, line, match, all_members = False):
        name = match['name'].strip()
        if 'type' in match and match['type']:
            name += " : " + match['type']

        self.add_line('.. swift:class:: ' + name, '<autodoc>')
        self.indent += self.content_indent
        self.add_line('', '<autodoc>')

        # add documentation block if there is one
        for l in self.get_doc_block(content, line - 1):
            self.add_line(l, '<autodoc>')

        self.add_line('', '<autodoc>')

        # document members
        if content[line].rstrip()[-1] == '{':
            self.document_members(content, line + 1)
        else:
            for i in range(line + 1, len(content)):
                l = content[i].lstrip()
                if len(l) > 0 and l[0] == '{':
                    self.document_members(content, i + 1, all_members=all_members)

        self.indent = self.indent[:-len(self.content_indent)]

    def document_members(self, content, line, all_members=False):

        braces = 1
        for i in range(line, len(content)):
            l = content[i]

            # balance braces
            open_braces = l.count('{')
            close_braces = l.count('}')
            braces = braces + open_braces - close_braces
            if braces <= 0:
                break

            # match functions
            match = self.func_pattern.match(l)
            if match:
                match = match.groupdict()
                if match['scope'].strip() == 'public' or all_members:
                    self.document_member(content, i, match)
                continue

            # match initializers
            match = self.init_pattern.match(l)
            if match:
                match = match.groupdict()
                if match['scope'].strip() == 'public' or all_members:
                    self.document_member(content, i, match)
                continue


    def document_member(self, content, line, match):
        sig = ''
        if 'name' in match:
            sig = match['name'].strip()
        else:
            sig = 'init'
        if match['rest']:
            sig += match['rest'].strip()

        if 'name' in match:
            if match['static'] == 'class':
                self.add_line('.. swift:class_method:: ' + sig, '<autodoc>')
            else:
                self.add_line('.. swift:method:: ' + sig, '<autodoc>')
        else:
            self.add_line('.. swift:init:: ' + sig, '<autodoc>')

        self.indent += self.content_indent
        self.add_line('', '<autodoc>')

        # add description to text
        last_item = None
        for l in self.get_doc_block(content, line - 1):
            match = self.param_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['param', match['param'], match['desc']]
                continue
            match = self.return_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['return', match['desc']]
                continue
            match = self.throws_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['throws', match['desc']]
                continue
            if last_item and l == '':
                self.emit_item(last_item)
                last_item = None
                continue
            if not last_item:
                self.add_line(l, '<autodoc>')
                continue
            last_item[len(last_item) - 1] += l

        if last_item:
            self.emit_item(last_item)

        self.add_line('', '<autodoc>')

        self.indent = self.indent[:-len(self.content_indent)]

    def emit_item(self, item):
        if item[0] == 'param':
            self.add_line(':parameter '+ item[1] +': ' + item[2], '<autodoc>')
        elif item[0] == 'return':
            self.add_line(':returns: ' + item[1], '<autodoc>')
        elif item[0] == 'throws':
            self.add_line(':throws: ' + item[1], '<autodoc>')
