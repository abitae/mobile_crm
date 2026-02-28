import React from 'react';
import { View, Text, TextInput, ScrollView, Pressable, StyleSheet } from 'react-native';
import { ArrowLeft } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../../theme';

interface AddUserFormProps {
  onBack: () => void;
  onSubmit: (data: { name: string; role: string; city: string }) => void;
}

export function AddUserForm({ onBack, onSubmit }: AddUserFormProps) {
  const [name, setName] = React.useState('');
  const [role, setRole] = React.useState('');
  const [city, setCity] = React.useState('');

  const handleSubmit = () => {
    if (!name.trim() || !role.trim() || !city.trim()) return;
    onSubmit({ name: name.trim(), role: role.trim(), city: city.trim() });
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backBtn}>
          <ArrowLeft size={18} color={colors.zinc[900]} />
        </Pressable>
        <Text style={styles.title}>Nuevo Datero</Text>
      </View>
      <View style={styles.form}>
        <Text style={styles.label}>Nombre Completo</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. Juan Pérez"
          placeholderTextColor={colors.zinc[400]}
          value={name}
          onChangeText={setName}
        />
        <Text style={styles.label}>Cargo</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. Asesor"
          placeholderTextColor={colors.zinc[400]}
          value={role}
          onChangeText={setRole}
        />
        <Text style={styles.label}>Ciudad</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. Lima"
          placeholderTextColor={colors.zinc[400]}
          value={city}
          onChangeText={setCity}
        />
        <Pressable onPress={handleSubmit} style={styles.submitBtn}>
          <Text style={styles.submitText}>Guardar Registro</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.lg },
  header: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg },
  backBtn: { padding: 6, backgroundColor: colors.white, borderWidth: 1, borderColor: colors.zinc[100], borderRadius: borderRadius.sm },
  title: { fontSize: 18, fontWeight: '700', color: colors.zinc[900] },
  form: { backgroundColor: colors.white, padding: spacing.lg, borderRadius: borderRadius.xl, borderWidth: 1, borderColor: colors.zinc[100], gap: spacing.md },
  label: { fontSize: 9, fontWeight: '700', color: colors.zinc[400], letterSpacing: 1, marginLeft: 4 },
  input: {
    backgroundColor: colors.zinc[50],
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.sm,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    fontSize: 12,
  },
  submitBtn: { backgroundColor: colors.blue[500], paddingVertical: spacing.md, borderRadius: borderRadius.xl, alignItems: 'center' },
  submitText: { color: colors.white, fontWeight: '700', fontSize: 14 },
});
