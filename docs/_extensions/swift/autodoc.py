import re
import fnmatch
import os

from sphinx.ext.autodoc import Documenter, bool_option

# member patterns
func_pattern = re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<static>class\s|static\s+|mutating\s+)?func\s+(?P<name>[a-zA-Z_][a-zA-Z0-9_]*\b)(?P<rest>[^{]*)')
init_pattern = re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+|convenience\s+)*init\s*(?P<rest>[^{]*)')
var_pattern  = re.compile(r'\s*(final\s+)?(?P<add_scope>private\s*\(set\)\s+|private\s*\(get\)\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<static>static\s+)?(?P<type>var\s+|let\s+)(?P<name>[a-zA-Z_][a-zA-Z0-9_]*\b)(?P<rest>[^{]*)(?P<computed>\s*{\s*)?')
case_pattern  = re.compile(r'\s*(case\s+)(?P<name>[a-zA-Z_][a-zA-Z0-9_]*\b)(\s*(?P<assoc_type>\([a-zA-Z_[(][a-zA-Z0-9_<>[\]()?!:, \t-]*\))\s*)?(\s*=\s*(?P<raw_value>.*))?')

# markdown doc patterns
param_pattern   = re.compile(r'^\s*- [pP]arameter\s*(?P<param>[^:]*):\s*(?P<desc>.*)')
return_pattern  = re.compile(r'^\s*- [rR]eturn[s]?\s*:\s*(?P<desc>.*)')
throws_pattern  = re.compile(r'^\s*- [tT]hrow[s]?\s*:\s*(?P<desc>.*)')
default_pattern = re.compile(r'^\s*- [dD]efault[s]?\s*:\s*(?P<desc>.*)')

# signatures
def class_sig(name=r'[a-zA-Z_][a-zA-Z0-9_]*'):
    return re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<struct>class)\s+(?P<name>' + name + r'\b)(\s*:\s*(?P<type>[^{]*))*')

def enum_sig(name=r'[a-zA-Z_][a-zA-Z0-9_]*'):
    return re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<struct>enum)\s+(?P<name>' + name + r'\b)(\s*:\s*(?P<type>[^{]*))*')

def struct_sig(name=r'[a-zA-Z_][a-zA-Z0-9_]*'):
    return re.compile(r'\s*(final\s+)?(?P<scope>private\s+|public\s+|internal\s+)?(final\s+)?(?P<struct>struct)\s+(?P<name>' + name + r'\b)(\s*:\s*(?P<type>[^{]*))*')


class SwiftAutoDocumenter(Documenter):
    option_spec = {
        'noindex': bool_option,
        'norecursivemembers': bool_option
    }

    def __init__(self, *args, **kwargs):
        super(SwiftAutoDocumenter, self).__init__(*args, **kwargs)

        self.append_at_end = []
        self.files = []
        for path in self.env.config.swift_search_path:
            for root, dirnames, filenames in os.walk(path):
                for filename in fnmatch.filter(filenames, '*.swift'):
                    self.files.append(os.path.join(root, filename))

    def generate(self, **kwargs):
        all_members = kwargs.get('all_members', False)
        sig_pattern = kwargs.get('sig_pattern', None)

        if not sig_pattern:
            raise Exception("sig_pattern is required")

        # split name by dots to get nesting state
        name_parts = self.name.split('.')
        name = name_parts[-1]
        name_parts = name_parts[:-1]
        signature = sig_pattern(name=name)

        # as we can nest enums, classes and structs we have to track state
        self.boxed_patterns = [class_sig(), enum_sig(), struct_sig()]

        # find class in swift files
        for file in self.files:
            self.box_stack = []
            braces = 0
            with open(file, "r") as fp:
                content = fp.readlines()
                for (index, line) in enumerate(content):
                    open_braces = line.count('{')
                    close_braces = line.count('}')
                    braces = braces + open_braces - close_braces

                    match = signature.match(line)
                    if match:
                        match = match.groupdict()
                        scope = match['scope'].strip() if match['scope'] else 'internal'
                        if scope == 'public' or all_members:
                            self.box_stack.append((braces, match['name']))
                            if len(self.box_stack) - 1 != len(name_parts):
                                continue
                            for i, (braces, item) in enumerate(self.box_stack[:-1]):
                                if item != name_parts[i]:
                                    continue
                            self.file = file
                            self.lineNo = index
                            self.content = content
                            print(self.name, 'found in', file, ':', index)
                            self.document_class(index, match, all_members=all_members)
                            return
                    else:
                        # remove box item when we leave
                        if len(self.box_stack) > 0 and self.box_stack[-1][0] == braces - 1:
                            self.box_stack.pop()

                        # track boxed context
                        for pattern in self.boxed_patterns:
                            match = pattern.match(line)
                            if match:
                                match = match.groupdict()
                                self.box_stack.append((braces, match['name']))
        self.env.warn(
            self.env.docname,
            'can not find "%s" in any file!' % self.name)

    def document_members(self, line, all_members=False):
        braces = 1
        for i in range(line, len(self.content)):
            l = self.content[i]

            # balance braces
            open_braces = l.count('{')
            close_braces = l.count('}')
            braces = braces + open_braces - close_braces
            if braces <= 0:
                break

            match = self.find_members(l, all_members=all_members)
            if match:
                self.document_member(i, match)

        for l in self.append_at_end:
            self.add_line(l, '<autodoc>')

    def get_doc_block(self, line):
        # search upwards for documentation lines
        doc_block = []
        for i in range(line, 0, -1):
            l = self.content[i].strip()
            if l.startswith('///'):
                converted = l[4:].rstrip()
                converted = converted.replace('`', '``')
                doc_block.append(converted)
                continue
            break
        return doc_block

    def find_members(self, line, all_members=False):
        # match members
        for pattern in self.member_patterns:
            match = pattern.match(line)
            if match:
                match = match.groupdict()
                if 'scope' in match:
                    scope = match['scope'].strip() if match['scope'] else 'internal'
                else:
                    scope = 'public'
                if scope == 'public' or all_members:
                    return match

        # recursive search for nested members
        if 'norecursivemembers' not in self.options:
            for pattern in self.boxed_patterns:
                match = pattern.match(line)
                if match:
                    match = match.groupdict()
                    name = ''
                    if len(self.box_stack) > 0:
                        for braces, super_name in self.box_stack:
                            name += super_name + '.'
                    name += match['name'].strip()

                    self.append_at_end.append('.. autoswift' + match['struct'] + ':: ' + name)
                    if 'noindex' in self.options:
                        self.append_at_end.append(self.content_indent + ':noindex:')
        return None

    def document_member(self, line, match):
        sig = ''
        if 'name' in match:
            sig = match['name'].strip()
        else:
            sig = 'init'
        if 'rest' in match and match['rest']:
            sig += match['rest'].strip()

        if 'type' in match:
            # so this is a variable
            if match['static'] == 'static':
                self.add_line('.. swift:static_' + match['type'].strip() + ':: ' + sig, '<autodoc>')
            else:
                self.add_line('.. swift:' + match['type'].strip() + ':: ' + sig, '<autodoc>')
        elif 'assoc_type' in match:
            # this is an enum case
            if match['assoc_type']:
                self.add_line('.. swift:enum_case:: ' + sig + match['assoc_type'], '<autodoc>')
            elif match['raw_value']:
                self.add_line('.. swift:enum_case:: ' + sig + ' = ' + match['raw_value'], '<autodoc>')
            else:
                self.add_line('.. swift:enum_case:: ' + sig, '<autodoc>')
        else:
            # this is a function of some kind
            if 'name' in match:
                if match['static'] == 'class':
                    self.add_line('.. swift:class_method:: ' + sig, '<autodoc>')
                else:
                    self.add_line('.. swift:method:: ' + sig, '<autodoc>')
            else:
                self.add_line('.. swift:init:: ' + sig, '<autodoc>')

        self.indent += self.content_indent

        if 'noindex' in self.options:
            self.add_line(':noindex:', '<autodoc>')

        self.add_line('', '<autodoc>')

        # add description to text
        last_item = None
        for l in self.get_doc_block(line - 1):
            match = param_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['param', match['param'], match['desc']]
                continue
            match = return_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['return', match['desc']]
                continue
            match = throws_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['throws', match['desc']]
                continue
            match = default_pattern.match(l)
            if match:
                if last_item:
                    self.emit_item(last_item)
                match = match.groupdict()
                last_item = ['defaults', match['desc']]
                continue
            if last_item and l == '':
                self.emit_item(last_item)
                self.add_line('', '<autodoc>')
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
        elif item[0] == 'defaults':
            self.add_line(':defaults: ' + item[1], '<autodoc>')


class SwiftClassAutoDocumenter(SwiftAutoDocumenter):
    objtype = 'swiftclass'
    member_patterns = [func_pattern, init_pattern, var_pattern]

    def generate(self, **kwargs):
        print('autoswiftclass', self.name.strip())
        super(SwiftClassAutoDocumenter, self).generate(sig_pattern=class_sig, **kwargs)

    def document_class(self, line, match, all_members = False):
        name = ''
        if len(self.box_stack) > 1:
            for braces, super_name in self.box_stack[:-1]:
                name += super_name + '.'

        name += match['name'].strip()
        if 'type' in match and match['type']:
            name += " : " + match['type']

        self.add_line('.. swift:class:: ' + name, '<autodoc>')
        self.indent += self.content_indent
        if 'noindex' in self.options:
            self.add_line(':noindex:', '<autodoc>')
        self.add_line('', '<autodoc>')

        # add documentation block if there is one
        for l in self.get_doc_block(line - 1):
            self.add_line(l, '<autodoc>')

        self.add_line('', '<autodoc>')

        # document members
        if self.content[line].rstrip()[-1] == '{':
            self.document_members(line + 1, all_members=all_members)
        else:
            for i in range(line + 1, len(self.content)):
                l = self.content[i].lstrip()
                if len(l) > 0 and l[0] == '{':
                    self.document_members(i + 1, all_members=all_members)

        self.indent = self.indent[:-len(self.content_indent)]


class SwiftStructAutoDocumenter(SwiftAutoDocumenter):
    objtype = 'swiftstruct'
    member_patterns = [func_pattern, init_pattern, var_pattern]

    def generate(self, **kwargs):
        print('autoswiftstruct', self.name.strip())
        super(SwiftStructAutoDocumenter, self).generate(sig_pattern=struct_sig, **kwargs)

    def document_class(self, line, match, all_members = False):
        name = ''
        if len(self.box_stack) > 1:
            for braces, super_name in self.box_stack[:-1]:
                name += super_name + '.'

        name += match['name'].strip()
        if 'type' in match and match['type']:
            name += " : " + match['type']

        self.add_line('.. swift:struct:: ' + name, '<autodoc>')
        self.indent += self.content_indent
        if 'noindex' in self.options:
            self.add_line(':noindex:', '<autodoc>')
        self.add_line('', '<autodoc>')

        # add documentation block if there is one
        for l in self.get_doc_block(line - 1):
            self.add_line(l, '<autodoc>')

        self.add_line('', '<autodoc>')

        # document members
        if self.content[line].rstrip()[-1] == '{':
            self.document_members(line + 1, all_members=all_members)
        else:
            for i in range(line + 1, len(self.content)):
                l = self.content[i].lstrip()
                if len(l) > 0 and l[0] == '{':
                    self.document_members(i + 1, all_members=all_members)

        self.indent = self.indent[:-len(self.content_indent)]


class SwiftEnumAutoDocumenter(SwiftAutoDocumenter):
    objtype = 'swiftenum'
    member_patterns = [func_pattern, init_pattern, var_pattern, case_pattern]

    def generate(self, **kwargs):
        print('autoswiftstruct', self.name.strip())
        super(SwiftEnumAutoDocumenter, self).generate(sig_pattern=enum_sig, **kwargs)

    def document_class(self, line, match, all_members = False):
        name = ''
        if len(self.box_stack) > 1:
            for braces, super_name in self.box_stack[:-1]:
                name += super_name + '.'

        name += match['name'].strip()
        if 'type' in match and match['type']:
            name += " : " + match['type']

        self.add_line('.. swift:enum:: ' + name, '<autodoc>')
        self.indent += self.content_indent
        if 'noindex' in self.options:
            self.add_line(':noindex:', '<autodoc>')
        self.add_line('', '<autodoc>')

        # add documentation block if there is one
        for l in self.get_doc_block(line - 1):
            self.add_line(l, '<autodoc>')

        self.add_line('', '<autodoc>')

        # document members
        if self.content[line].rstrip()[-1] == '{':
            self.document_members(line + 1, all_members=all_members)
        else:
            for i in range(line + 1, len(self.content)):
                l = self.content[i].lstrip()
                if len(l) > 0 and l[0] == '{':
                    self.document_members(i + 1, all_members=all_members)

        self.indent = self.indent[:-len(self.content_indent)]
