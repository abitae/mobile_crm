import React from 'react';
import { View, Text, TextInput, ScrollView, Pressable, StyleSheet } from 'react-native';
import { ArrowLeft } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../../theme';
import type { Client, Project } from '../../types';

interface AddReservationFormProps {
  clients: Client[];
  projects: Project[];
  onBack: () => void;
  onSubmit: (data: { clientId: string; projectId: string; unit: string; date: string; amount: number }) => void;
}

export function AddReservationForm({ clients, projects, onBack, onSubmit }: AddReservationFormProps) {
  const [clientId, setClientId] = React.useState('');
  const [projectId, setProjectId] = React.useState('');
  const [unit, setUnit] = React.useState('');
  const [date, setDate] = React.useState('');
  const [amount, setAmount] = React.useState('');

  const handleSubmit = () => {
    if (!clientId || !projectId || !unit.trim() || !date.trim() || !amount.trim()) return;
    const num = Number(amount);
    if (isNaN(num)) return;
    onSubmit({ clientId, projectId, unit: unit.trim(), date: date.trim(), amount: num });
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backBtn}>
          <ArrowLeft size={18} color={colors.zinc[900]} />
        </Pressable>
        <Text style={styles.title}>Nueva Reserva</Text>
      </View>
      <View style={styles.form}>
        <Text style={styles.label}>Cliente</Text>
        <View style={styles.pickerWrap}>
          {clients.map((c) => (
            <Pressable key={c.id} onPress={() => setClientId(c.id)} style={[styles.option, clientId === c.id && styles.optionActive]}>
              <Text style={[styles.optionText, clientId === c.id && styles.optionTextActive]}>{c.name}</Text>
            </Pressable>
          ))}
        </View>
        <Text style={styles.label}>Proyecto</Text>
        <View style={styles.pickerWrap}>
          {projects.map((p) => (
            <Pressable key={p.id} onPress={() => setProjectId(p.id)} style={[styles.option, projectId === p.id && styles.optionActive]}>
              <Text style={[styles.optionText, projectId === p.id && styles.optionTextActive]}>{p.title}</Text>
            </Pressable>
          ))}
        </View>
        <Text style={styles.label}>Unidad</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. A-101"
          placeholderTextColor={colors.zinc[400]}
          value={unit}
          onChangeText={setUnit}
        />
        <Text style={styles.label}>Monto ($)</Text>
        <TextInput
          style={styles.input}
          placeholder="0.00"
          placeholderTextColor={colors.zinc[400]}
          value={amount}
          onChangeText={setAmount}
          keyboardType="decimal-pad"
        />
        <Text style={styles.label}>Fecha</Text>
        <TextInput
          style={styles.input}
          placeholder="YYYY-MM-DD"
          placeholderTextColor={colors.zinc[400]}
          value={date}
          onChangeText={setDate}
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
  pickerWrap: { gap: 4 },
  option: { paddingVertical: spacing.sm, paddingHorizontal: spacing.md, borderRadius: borderRadius.sm, backgroundColor: colors.zinc[50] },
  optionActive: { backgroundColor: colors.blue[100] },
  optionText: { fontSize: 12, color: colors.zinc[600] },
  optionTextActive: { color: colors.blue[700], fontWeight: '600' },
  submitBtn: { backgroundColor: colors.blue[600], paddingVertical: spacing.md, borderRadius: borderRadius.xl, alignItems: 'center' },
  submitText: { color: colors.white, fontWeight: '700', fontSize: 14 },
});
